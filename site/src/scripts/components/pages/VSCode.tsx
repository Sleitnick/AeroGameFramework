import * as React from "react";

export default class VSCode extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>
				<h1>Visual Studio Code</h1>

				<hr/>

				<p>
					For the best development experience, it is highly recommended to
					use <a href="https://code.visualstudio.com/" target="_blank">Visual Studio Code</a> for
					writing code within the framework. AeroGameFramework includes a VS Code extension,
					and ties in with other useful applications as well (such as Rojo and Luacheck).
				</p>

				<hr/>

				<h3>Requirements</h3>
				<table className="table table-striped">
					<thead>
						<tr>
							<th>Name</th>
							<th>Description</th>
							<th>Required</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><a href="https://marketplace.visualstudio.com/items?itemName=aerogameframework-vsce.aerogameframework" target="_blank">AeroGameFramework</a></td>
							<td>Main VS Code extension</td>
							<td className="text-success">Yes</td>
						</tr>
						<tr>
							<td><a href="https://lpghatguy.github.io/rojo/0.4.x/getting-started/installation/" target="_blank">Rojo</a></td>
							<td>Sync files between VS Code and Roblox Studio</td>
							<td className="text-success">Yes</td>
						</tr>
						<tr>
							<td><a href="https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo" target="_blank">Rojo for VS Code</a></td>
							<td>Use and manage Rojo directly from VS Code</td>
							<td className="text-muted">No</td>
						</tr>
						<tr>
							<td><a href="https://github.com/mpeterv/luacheck" target="_blank">Luacheck</a></td>
							<td>Static analyzer and linter for Lua</td>
							<td className="text-muted">No (<span className="text-success">Yes</span> if using vscode-lua)</td>
						</tr>
						<tr>
							<td><a href="https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua" target="_blank">vscode-lua</a></td>
							<td>Intellisense and linting for Lua (utilizes Luacheck)</td>
							<td className="text-muted">No</td>
						</tr>
					</tbody>
				</table>

				<hr/>

				<h3>Project Setup</h3>
				<ol>
					<li>Create a new directory for your project</li>
					<li>Open the directory within VS Code (<code className="text-muted">File > Open Folder...</code>)</li>
					<li>From the command panel <code className="text-muted">(Ctrl+Shift+P)</code>, run <code className="text-success">AeroGameFramework: Init</code></li>
					<li>If using the Rojo VS Code extension, restart VS Code</li>
					<li>Start Rojo and run the Rojo plugin within Roblox Studio</li>
				</ol>

				<hr/>

				<h3>Directory Structure</h3>
				<ul className="list-unstyled dir-tree">
					<li>
						<code>src</code>: Where all the source files live
						<ul className="list-unstyled">
							<li>
								<code>Client</code>: All the client-side code
								<ul className="list-unstyled">
									<li><code>Controllers</code>: Client-side singleton controllers</li>
									<li><code>Modules</code>: Lazy-loaded plain modules</li>
								</ul>
							</li>
						</ul>
						<ul className="list-unstyled">
							<li>
								<code>Server</code>: All the server-side code
								<ul className="list-unstyled">
									<li><code>Services</code>: Server-side singleton services</li>
									<li><code>Modules</code>: Lazy-loaded plain modules</li>
								</ul>
							</li>
						</ul>
					</li>
					<li><code>Shared</code>: Lazy-loaded plain modules shared between the client and server</li>
					<li><code>_framework</code>: Internal framework source files (Hidden within VS Code)</li>
				</ul>

				<p>
					<b>Note:</b> The <code className="text-muted">rojo.json</code> file is specifically configured to work with
					the directory structure described above. Changing the structure may break Rojo from properly syncing changes
					into Roblox Studio.
				</p>

				<hr/>

				<h3>Creating new source files (Services, Controllers, and Modules)</h3>

				<ol>
					<li>Right-click within the Explorer and click on <code className="text-success">AeroGameFramework: Create</code> from the context menu</li>
					<li>Select whether the source file should exist within the Server, Client or Shared</li>
					<li>Select the source type (e.g. Serv,ce Controller, or Module)</li>
					<li>Type in the name and press Enter</li>
				</ol>
				<p>
					<b>Tip:</b> If you right-click within given directories, the extension will automatically assume the
					desired file type. For instance, if you right-click on Services and click Create, the extension will
					immediately prompt for a new service name.
				</p>
				<p>
					<b>Tip:</b> If you right-click and click Create on an existing source file, you can create nested
					modules within the existing file. This will automatically create the necessary Rojo structure. Please
					note that nested modules do not get consumed by the framework and must be required manually.
				</p>

			</div>
		);
	}

}