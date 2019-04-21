import * as React from "react";

export default class Header extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div className="header">
				<div className="header-content">
					<h1>AeroGameFramework</h1>
				</div>
			</div>
		);
	}

}