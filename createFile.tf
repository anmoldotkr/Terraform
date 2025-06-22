resource "local_file" "my_file" {

    filename = "automate.txt"
    content = "This text file is created by terraform"  
}