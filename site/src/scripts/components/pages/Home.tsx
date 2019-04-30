import * as React from "react";

export default class Home extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>
				<h1>Home</h1>
				<hr/>
				<h3>About</h3>
				<p>
					AeroGameFramework is a Roblox game framework that makes development easy and
					fun. The framework is designed to simplify the communication between modules
					and seamlessly bridge the gap between the server and client. Never again will
					you have to touch RemoteFunctions or RemoteEvents.
				</p>
				<hr/>
				<h3>Documentation</h3>
				<p>
					This site is under development. Documentation is coming soon.
					Please visit the <a href="https://github.com/Sleitnick/AeroGameFramework" target="_blank">GitHub repository</a> for more information.
				</p>
			</div>
		);
	}

}