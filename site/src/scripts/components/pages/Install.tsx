import * as React from "react";
import { NavLink } from "react-router-dom";

export default class VSCode extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>
				<h1>Install & Setup</h1>

				<hr/>

				<p>
					The preferred editor for the AeroGameFramework is <a href="https://code.visualstudio.com/" target="_blank">Visual Studio Code</a>.
					AeroGameFramework includes a VS Code extension, and ties in with other useful extensions &
					plugins (such as Rojo and Luacheck).
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
							<td><a href="https://rojo.space/docs/latest/guide/installation/" target="_blank">Rojo</a></td>
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
					<li>Enable HTTP requests within your Roblox game settings</li>
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
									<li><NavLink to="/controllers"><code>Controllers</code></NavLink>: Client-side singleton controllers</li>
									<li><NavLink to="/modules"><code>Modules</code></NavLink>: Lazy-loaded plain modules</li>
								</ul>
							</li>
						</ul>
						<ul className="list-unstyled">
							<li>
								<code>Server</code>: All the server-side code
								<ul className="list-unstyled">
									<li><NavLink to="/services"><code>Services</code></NavLink>: Server-side singleton services</li>
									<li><NavLink to="/modules"><code>Modules</code></NavLink>: Lazy-loaded plain modules</li>
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

				<h3>AGF Treeview</h3>

				<p>
					The VS Code extension for AeroGameFramework provides a simplified directory hierarchy that will only show
					the source files that should be edited. In other words, it hides all of the files that you do not need to
					worry about. This view can be selected from the "AGF" icon on the left-hand panel in VS Code.
				</p>

				<hr/>

				<h3>Creating new source files (Services, Controllers, and Modules)</h3>

				<ol>
					<li>Right-click within the AGF Treeview and click on <code className="text-success">AeroGameFramework: Create</code> from the context menu, <i>or</i> click the Script Add button at the top</li>
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
				<p>
					<b>Note:</b> When creating a Module, a prompt will show up to choose between a Plain Module and a
					Class Module. A Plain Module is just a typical ModuleScript with an empty table defined. A Class
					Module contains the necessary boilerplate code for basic OOP modules.
				</p>

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