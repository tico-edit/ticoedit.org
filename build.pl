#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long qw( GetOptions );
use HTTP::Tiny;
use JSON::MaybeXS ();
use Path::Tiny qw( path );
use XOR 0.11;

GetOptions(
  'release' => \my $release,
) or die "usage: $0 [--release]\n";

update_downloads() if $release;

my $xor = XOR->new(
  root => '.',
  org  => 'tico-edit',
  site_name => 'tico',
);

$xor->builder->build;

# Regenerate docs/download.json from the binary packages in the latest
# tico release.  This deliberately doesn't use XOR's web client, which
# caches responses for 24 hours.
sub update_downloads
{
  my $url = 'https://api.github.com/repos/tico-edit/tico/releases/latest';
  my $res = HTTP::Tiny->new->get($url, { headers => { Accept => 'application/vnd.github+json' } });
  die "error fetching $url: $res->{status} $res->{reason}\n" unless $res->{success};
  my $latest = JSON::MaybeXS->new( utf8 => 1 )->decode($res->{content});

  my %arch = (
    aarch64 => 'ARM64',
    arm64   => 'ARM64',
    i686    => 'x86',
    i386    => 'x86',
    x86_64  => 'x86_64',
    amd64   => 'x86_64',
  );

  my %type = (
    '.tar.gz'        => 'tarball',
    '.zip'           => 'zip',
    '-installer.exe' => 'installer',
  );

  my @rows;
  foreach my $asset (@{ $latest->{assets} })
  {
    my $name = $asset->{name};
    my($os, $arch, $type);

    # tico-vVERSION-ARCH-VENDOR-OS[-ABI]{.tar.gz,.zip,-installer.exe}
    if($name =~ /^tico-v[0-9][^-]*-([^-]+)-([^-]+-[^-]+(?:-[^-]+)?)(\.tar\.gz|\.zip|-installer\.exe)$/)
    {
      ($arch, $os, $type) = ($1, $2, $type{$3});
      $os = $os =~ /linux/   ? 'Linux'
          : $os =~ /darwin/  ? 'macOS'
          : $os =~ /windows/ ? 'Windows'
          : $os;
    }
    # tico_VERSION_ARCH.deb
    elsif($name =~ /^tico_[^_]+_([^_]+)\.deb$/)
    {
      ($arch, $os, $type) = ($1, 'Linux', 'debian package');
    }
    else
    {
      warn "warning: skipping $name\n";
      next;
    }

    push @rows, [ [ $name, $asset->{browser_download_url} ], $os, $arch{$arch} // $arch, $type ];
  }

  die "no binary packages found in $latest->{tag_name}\n" unless @rows;

  @rows = sort {
    lc $a->[1] cmp lc $b->[1]
      || lc $a->[2] cmp lc $b->[2]
      || $a->[3] cmp $b->[3]
      || $a->[0][0] cmp $b->[0][0]
  } @rows;

  path('docs/download.json')->spew_raw(
    JSON::MaybeXS->new( utf8 => 1, canonical => 1, pretty => 1 )->encode({
      header => [ 'File', 'OS', 'Arch', 'Type' ],
      rows   => \@rows,
    })
  );
}
