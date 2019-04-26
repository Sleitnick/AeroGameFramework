import * as React from "react";
import { NavLink } from "react-router-dom";

export default class Nav extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<nav className="nav flex-column">
				<NavLink className="nav-link-item" activeClassName="active-nav" to="/home">Home</NavLink>
				<NavLink className="nav-link-item" activeClassName="active-nav" to="/gettingstarted">Getting Started</NavLink>
			</nav>
		);
	}

}