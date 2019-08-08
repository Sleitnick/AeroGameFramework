import * as React from "react";
import { NavLink } from "react-router-dom";

interface AGFNavLinkProps {
	to: string;
}

class AGFNavLink extends React.Component<AGFNavLinkProps> {
	public constructor(props: AGFNavLinkProps) {
		super(props);
	}
	public render(): JSX.Element {
		return <NavLink className="nav-link-item" activeClassName="active-nav" to={this.props.to}>{this.props.children}</NavLink>
	}
}

export default class Nav extends React.Component {

	public constructor(props) {
		super(props);
	}

	public render(): JSX.Element {
		return (
			<nav className="nav flex-column">
				<AGFNavLink to="/home">Home</AGFNavLink>
				<AGFNavLink to="/install">Install & Setup</AGFNavLink>
				<AGFNavLink to="/services">Services</AGFNavLink>
				<AGFNavLink to="/controllers">Controllers</AGFNavLink>
				<AGFNavLink to="/modules">Modules</AGFNavLink>
				<AGFNavLink to="/executionmodel">Execution Model</AGFNavLink>
				<hr className="w-100 d-block d-md-none"/>
			</nav>
		);
	}

}