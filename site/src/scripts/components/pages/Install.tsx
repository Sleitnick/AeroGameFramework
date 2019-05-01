import * as React from "react";

export default class GettingStarted extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>

				<h1>Install</h1>

				<hr/>

				<h3>Install & Update</h3>
				<p>
					Download the <a href="https://www.roblox.com/library/1882232354/AeroGameFramework-Plugin" target="_blank">AeroGameFramework</a> plugin
					for Roblox Studio. Once installed, open up a game, enable HTTP requests, and then run the installer from the plugin. The installer
					can be run again at any point to fetch new updates. For any update, you will be prompted per file whether or not to apply the new
					update. If desired, remember to disable HTTP requests after the installation or update has completed.
				</p>
				<iframe width="560" height="315" src="https://www.youtube.com/embed/xSgTzMpMIpA" frameBorder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowFullScreen></iframe>

				<hr/>

				<h3>Roblox Structure</h3>
				<p>AeroGameFramework is structured into three major categories: Server, Client, and Shared.</p>
				<table className="table table-striped">
					<thead>
						<tr>
							<th>Environment</th>
							<th>Location</th>
							<th>Description</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>Server</td>
							<td><code>ServerStorage.Aero</code></td>
							<td>Server-side code</td>
						</tr>
						<tr>
							<td>Client</td>
							<td><code>StarterPlayerScripts.Aero</code></td>
							<td>Client-side code</td>
						</tr>
						<tr>
							<td>Shared</td>
							<td><code>ReplicatedStorage.Aero</code></td>
							<td>Shared modules between the server and client</td>
						</tr>
					</tbody>
				</table>
				<p>
					<b>Note:</b> If developing within Visual Studio Code, these folders should be left untouched within Roblox Studio
					to prevent any unexpected data loss due to Rojo syncing.
				</p>

			</div>
		);
	}

}