import * as React from "react";
import { HashRouter as Router, Route, Redirect, Switch } from "react-router-dom";
import Header from "./Header";
import Nav from "./Nav";
import Home from "./pages/Home";
import Install from "./pages/Install";
import VSCode from "./pages/VSCode";
import Services from "./pages/Services";
import Controllers from "./pages/Controllers";
import Modules from "./pages/Modules";
import ExecutionModel from "./pages/ExecutionModel";
import NotFound from "./pages/NotFound";

export default class Index extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<Router>
				<div>
					<Header/>
					<div className="content">
						<div className="container-fluid">
							<div className="row">
								<div className="col-lg-2 col-md-2 col-sm-12">
									<Nav/>
								</div>
								<div className="col-lg-8 col-md-8 col-sm-12">
									<Switch>
										<Route exact path="/" render={() => <Redirect to="/home"/>}/>
										<Route exact path="/home" component={Home}/>
										<Route exact path="/install" component={Install}/>
										<Route exact path="/vscode" component={VSCode}/>
										<Route exact path="/services" component={Services}/>
										<Route exact path="/controllers" component={Controllers}/>
										<Route exact path="/modules" component={Modules}/>
										<Route exact path="/executionmodel" component={ExecutionModel}/>
										<Route component={NotFound}/>
									</Switch>
								</div>
							</div>
						</div>
					</div>
				</div>
			</Router>
		);
	}

}
