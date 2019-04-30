import * as React from "react";
import { NavLink } from "react-router-dom";

interface AGFNavLinkProps {
	to: string;
}

class AGFNavLink extends React.Component<AGFNavLinkProps> {
	constructor(props: AGFNavLinkProps) {
		super(props);
	}
	public render() {
		return <NavLink className="nav-link-item" activeClassName="active-nav" to={this.props.to}>{this.props.children}</NavLink>
	}
}

export default class Nav extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<nav className="nav flex-column">
				<AGFNavLink to="/home">Home</AGFNavLink>
				<AGFNavLink to="/install">Install</AGFNavLink>
				<AGFNavLink to="/vscode">Visual Studio Code</AGFNavLink>
				<AGFNavLink to="/services">Services</AGFNavLink>
				<AGFNavLink to="/controllers">Controllers</AGFNavLink>
				<AGFNavLink to="/modules">Modules</AGFNavLink>
				<AGFNavLink to="/executionmodel">Execution Model</AGFNavLink>
				<hr className="w-100 d-block d-md-none"/>
			</nav>
		);
	}

}