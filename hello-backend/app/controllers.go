package app

import (
	"github.com/zlorgoncho1/sprint/core"
)

// Controller Declaration
type AppController struct {
	Name string
	Path string
}

func (reflect AppController) Init() (string, string) {
	return reflect.Name, reflect.Path
}

// Controller Routes
func (reflect AppController) Routes() []core.Route {
	return []core.Route{
		{
			Endpoint: "",
			Method:   "GET",
			Function: reflect.Hello,
		},
	}
}

func (reflect AppController) Hello(request core.Request) core.Response {
	return core.Response{Content: "Hello World"}
}
