package app

import (
	"github.com/zlorgoncho1/sprint/core"
)

// Module Definition
var AppModule = core.Module{
	Name: "AppModule",
	Controllers: []core.Controller{
		AppController{Path: "hello", Name: "AppController"},
	},
	// TODO: static endpoint
}
