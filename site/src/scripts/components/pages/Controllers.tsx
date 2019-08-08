import * as React from "react";
import CodeBlock from "../CodeBlock";
import Markdown from "../Markdown"

import "../../lua/controller_01.lua";
import "../../lua/controller_02.lua";
import "../../lua/controller_03.lua";
import "../../lua/controller_04.lua";
import "../../lua/controller_05.lua";
import "../../lua/controller_06.lua";
import "../../lua/controller_07.lua";
import "../../lua/controller_08.lua";
import "../../lua/controller_09.lua";
import "../../lua/controller_10.lua";
import "../../lua/controller_11.lua";
import "../../lua/controller_12.lua";

export default class Controllers extends React.Component {

	public constructor(props) {
		super(props);
	}

	public render(): JSX.Element {
		return (
			<div>

				<Markdown>
				{`
					# Controllers

					A service is a singleton initiated at runtime on the server. Services should serve specific purposes. For instance,
					the provided DataService allows simplified data management. You might also create a WeaponService, which might
					be used for holding and figuring out weapon information for the players.

					A controller is a singleton initiated at runtime on the client. Controllers should serve a specific purpose. For
					instance, the provided Fade controller allows for control of simple screen fading. Controllers often interact
					with server-side services as well. Another example of a controller could be a Camera controller, which has the
					task of specifically controlling the player's camera.

					------------------

					### API

					A controller in its simplest form looks like this:
				`}
				</Markdown>
				<CodeBlock src="lua/controller_01.lua"/>

				<br/>

				<h5>Injected Properties:</h5>
				<table className="table table-striped">
					<thead>
						<tr>
							<th>Property</th>
							<th>Description</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><code><i>controller</i>.Controllers</code></td>
							<td>Table of all other controllers, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>controller</i>.Modules</code></td>
							<td>Table of all modules, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>controller</i>.Shared</code></td>
							<td>Table of all shared modules, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>controller</i>.Services</code></td>
							<td>Table of all server-side services, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>controller</i>.Player</code></td>
							<td>Reference to the LocalPlayer (<code>game.Players.LocalPlayer</code>)</td>
						</tr>
					</tbody>
				</table>

				<br/>
				
				<h5>Injected Methods:</h5>
				<table className="table table-striped">
					<thead>
						<tr>
							<th>Return</th>
							<th>Method</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>void</td>
							<td><code><i>controller</i>:WrapModule(Table tbl)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>controller</i>:RegisterEvent(String eventName)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>controller</i>:FireEvent(String eventName, ...)</code></td>
						</tr>
						<tr>
							<td>Connection</td>
							<td><code><i>controller</i>:ConnectEvent(String eventName, Function handler)</code></td>
						</tr>
					</tbody>
				</table>

				<Markdown>
				{`
					---------------------

					### \`controller:Init()\`
					
					The \`Init\` method is called on each controller in the framework in a synchronous and linear progression. In other
					words, each controller's \`Init\` method is invoked one after the other. Each \`Init\` method must fully execute before
					moving onto the next. This is essentially the constructor for the controller singleton.

					The method should be used to set up your controller. For instance, you might want to create events or reference other controllers.

					The \`Init\` method should _not_ invoke any methods from other controllers yet, because it is not guaranteed that those
					controllers have had their \`Init\` methods invoked yet. It is safe to _reference_ other controllers, but not to invoke their methods.

					Use the \`Init\` method to register events and initialize any necessary components before the \`Start\` method is invoked.

					---------------------

					### \`controller:Start()\`

					The \`Start\` method is called after all controllers have been initialized (i.e. their \`Init\` methods have been
					fully executed). Each \`Start\` method is executed on a _separate_ thread (asynchronously). From here, it is safe to reference
					and invoke other controllers in the framework.

					---------------------

					### Custom Methods

					Adding your own methods to a controller is very easy. Simply attach a function to the controller table:
					
				`}
				</Markdown>
				<CodeBlock src="lua/controller_02.lua"/>
				<Markdown>Other controllers can also invoke your custom method:</Markdown>
				<CodeBlock src="lua/controller_03.lua"/>

				<Markdown>
				{`
					---------------------

					### Events

					You can create and listen to events using the \`RegisterEvent\`, \`ConnectEvent\`, and \`FireEvent\` methods.
					All events should _always_ be registered within the \`Init\` method. The \`ConnectEvent\` and \`FireEvent\`
					methods should _never_ be used within an \`Init\` method.
				`}
				</Markdown>
				<CodeBlock src="lua/controller_04.lua"/>
				<Markdown>Alternatively, the Event object is available under Shared:</Markdown>
				<CodeBlock src="lua/controller_05.lua"/>

				<Markdown>
				{`
					---------------------

					### WrapModule

					The \`WrapModule\` method can be used to transform a table into a framework-like module. In other words, it sets
					the table's metatable to the same metatable used by other framework modules, thus exposing the framework to the
					given table.
				`}
				</Markdown>
				<CodeBlock src="lua/controller_06.lua"/>
				<Markdown>
				{`
					This can be useful if you are requiring other non-framework modules in which you want to expose the framework.

					---------------------

					## Other Examples

					##### Invoking another controller:
				`}
				</Markdown>
				<CodeBlock src="lua/controller_07.lua"/>
				<br/>
				<Markdown>##### Invoking a service:</Markdown>
				<CodeBlock src="lua/controller_08.lua"/>
				<br/>
				<Markdown>##### Using a module:</Markdown>
				<CodeBlock src="lua/controller_09.lua"/>
				<br/>
				<Markdown>##### Using a shared module:</Markdown>
				<CodeBlock src="lua/controller_10.lua"/>
				<br/>
				<Markdown>##### Connecting to a service event:</Markdown>
				<CodeBlock src="lua/controller_11.lua"/>
				<br/>
				<Markdown>##### Firing a service event:</Markdown>
				<CodeBlock src="lua/controller_12.lua"/>

				<Markdown>
				{`
					---------------------

					## No Server-to-Client Methods

					As you may have noticed, there is no way to create a method on a controller that a server-side
					service can invoke. This is by design. There are a lot of dangers in allowing
					the server to invoke client-side methods, and thus the framework simply does not supply a way
					of doing so. Internally, this would be allowed via \`remoteFunction:InvokeClient(...)\`. If
					the server needs information from a client, a client controller should fire a service event.

					For more information, please read the "Note" and "Warning" section under the [\`RemoteFunction:InvokeClient()\`
					documentation page](https://developer.roblox.com/en-us/api-reference/function/RemoteFunction/InvokeClient)
					and this [YouTube video](https://youtu.be/0H_xcA-0LDE) discussing the issue in more detail.
				`}
				</Markdown>

			</div>
		);
	}

}