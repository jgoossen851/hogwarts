// SAMPLE PROGRAM

#include<fstream>
#include<iostream>
#include<string>

int main(int argc, char* argv[]) {

  // Check for an argument
  if (argc < 2) {
    std::cerr << "Usage: " << argv[0] << " filename.myext" << std::endl;
    return 1;
  }

  std::cout << "Attempting to open file: " << argv[1] << std::endl;
  std::ifstream myfile(argv[1], std::ios::in);
  if (myfile.is_open()) {
    // Change print color
    std::cout << "\033[36m";
  
    // Print the file contents
    std::string line;
    while (getline(myfile, line)) {
      std::cout << line << std::endl;
    }
    
    // Reset color and close
    std::cout << "\033[0m";
    myfile.close();
  } else {
    std::cout << "Unable to open file." << std::endl;
  }
  
  // Wait for user input
  std::cout << "Press Enter:";
  getchar();
  
  return 0;
}
