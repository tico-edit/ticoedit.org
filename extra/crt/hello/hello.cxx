// hello.cxx: a friendly greeting from tico.

#include <iostream>
#include <string>
#include <vector>

int main(int argc, char *argv[])
{
    std::vector<std::string> names(argv + 1, argv + argc);
    if (names.empty())
        names.push_back("world");

    for (const auto &name : names)
        std::cout << "Hello, " << name << "!" << std::endl;

    return 0;
}
