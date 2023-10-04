package main

import (
	"hello-backend/app"

	server "github.com/zlorgoncho1/sprint/server"
)

func main() {
	server := server.Server{Host: "0.0.0.0", Port: "8000"}
	server.Start(app.AppModule)
}
