import * as React from "react";

export default class Home extends React.Component {

	public constructor(props) {
		super(props);
	}

	public render(): JSX.Element {
		return (
			<div>
				<h1>AeroGameFramework</h1>
				<p>
					AeroGameFramework is a Roblox game framework that makes development easy and
					fun. The framework is designed to simplify the communication between modules
					and seamlessly bridge the gap between the server and client. Never again will
					you have to touch RemoteFunctions or RemoteEvents.
				</p>
				<hr/>
				<h3>Collaborate</h3>
				<p>
					AeroGameFramework is an open-source project, and your support is much appreciated. Feel free to report bugs, suggest features,
					and make pull requests.
					Please visit the <a href="https://github.com/Sleitnick/AeroGameFramework" target="_blank" rel="noopener noreferrer">GitHub repository</a> for more information.
				</p>
				<p>
					The framework was built and is supported primary by <a href="https://github.com/Sleitnick" target="_blank" rel="noopener noreferrer">Stephen Leitnick</a>.
				</p>
			</div>
		);
	}

}