import * as React from "react";
import { NavLink } from "react-router-dom";

export default class Header extends React.Component {

	public constructor(props) {
		super(props);
	}

	public render(): JSX.Element {
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