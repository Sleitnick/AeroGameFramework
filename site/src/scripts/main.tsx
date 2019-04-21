import * as React from "react";
import { render } from "react-dom";
import Index from "./components/Index";

import "bootstrap";
import "../sass/main.scss";
import "../imgs/logo_32.png";

const appComponent = document.getElementById("app");

render(<Index/>, appComponent);
