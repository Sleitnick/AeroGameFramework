import * as React from "react";
import { HashRouter as Router, Route, Redirect, Switch } from "react-router-dom";
import Header from "./Header";
import Nav from "./Nav";
import Home from "./pages/Home";
import GettingStarted from "./pages/GettingStarted";
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
						<div className="row">
							<div className="col-2">
								<Nav/>
							</div>
							<div className="col-7">
								<Switch>
									<Route exact path="/" render={() => <Redirect to="/home"/>}/>
									<Route exact path="/home" component={Home}/>
									<Route exact path="/gettingstarted" component={GettingStarted}/>
									<Route component={NotFound}/>
								</Switch>
							</div>
						</div>
					</div>
				</div>
			</Router>
		);
	}

}
