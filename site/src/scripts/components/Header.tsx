import * as React from "react";
import { NavLink } from "react-router-dom";

export default class Header extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div className="header">
				<div className="header-content">
					<h1>
						<NavLink to="/home">AeroGameFramework</NavLink>
					</h1>
				</div>
			</div>
		);
	}

}