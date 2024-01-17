package main

import (
	"errors"
	"fmt"
)

type newString string

var err2 error = testErr(2)
Noting()
func main() {

	var err error = testErr(5)

	//TODO: err is CustomErr?

	printErr(err)
	printErr(err2)
}

func Channel() chan string {
	
}

func testErr(number int) error {
	if number%2 == 0 {
		return errors.New("Unknown error")
	}

	return CustomErr{message: "test message", error: errors.New("Custom error!")}
}

type CustomErr struct {
	message string
	error
}

func printErr(err error) {
	if customErr, ok := err.(CustomErr); ok {
		fmt.Println(customErr)
	} else {
		fmt.Print(err)
	}
}
