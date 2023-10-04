package main

import (
	"hello-backend/app"

	server "github.com/zlorgoncho1/sprint/server"
)

func main() {
	server := server.Server{Host: "localhost", Port: "8000"}
	server.Start(app.AppModule)
}
