std::cout<<"Enter the link: ";
std::string link;
std::cin>>link;
ShellExecute(NULL, "open", link.c_str(), NULL, NULL, SW_SHOWNORMAL);