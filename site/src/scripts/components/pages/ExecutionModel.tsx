import * as React from "react";

export default class ExecutionModel extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>
				<h1>Execution Model</h1>

				<hr/>

				<h3>Services and Controllers</h3>
				<p>Services and Controllers act as singletons. In other words, only one instance exists per service or controller in a given environment.</p>
				<ol>
					<li>All modules are loaded using <code>require()</code> at the start of runtime.</li>
					<li>All modules have properties and methods "injected" via metatable.</li>
					<li>Each <code>Init</code> method on the modules are invoked one-by-one synchronously.</li>
					<li>Each <code>Start</code> method on the modules are invoked asynchronously.</li>
					<li>The module remains in memory for the remainder of runtime.</li>
				</ol>

				<hr/>

				<h3>Modules and Shared</h3>
				<ol>
					<li>A module (in Modules or Shared) is loaded using <code>require()</code> the first time it is referenced (i.e. lazy-loaded).</li>
					<li>The module has properties and methods "injected" via metatable.</li>
					<li>The module's <code>Init</code> method is invoked synchronously.</li>
					<li>The module's <code>Start</code> method is invoked immediately and asynchronously after the <code>Init</code> method is completed.</li>
				</ol>

				<hr/>

				<h3>Notes and Best Practices</h3>
				<ul>
					<li>The <code>Init</code> and <code>Start</code> methods are always optional, but it is good practice to always include them.</li>
					<li>The <code>Init</code> method should be used to set up the individual module.</li>
					<li>The <code>Init</code> method should try to do as minimal work as possible, as other modules are blocked until it is completed.</li>
					<li>The <code>Init</code> method should <i>not</i> be used to invoke methods from other modules in the framework (that should be done in or after <code>Start</code>)</li>
					<li>Events <i>must</i> be registered in the <code>Init</code> method.</li>
					<li>Events should <i>never</i> be connected or fired within the <code>Init</code> method. Do this within the <code>Start</code> method.</li>
					<li>Because Modules and Shared modules are lazy-loaded, their <code>Init</code> methods are executed after other modules have been started.</li>
				</ul>

			</div>
		);
	}

}