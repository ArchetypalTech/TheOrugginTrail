import { LitElement, html, css } from 'lit';

class LitTerminal extends LitElement {
  declare inputValue: string;
  declare history: Array<string>;
  static get properties() {
    return {
      inputValue: { type: String },
      history: {type: Array}
    };
  }
  // static properties = (inputValue: {type: String}, history: {type: Array});
  constructor() {
    super();
    this.inputValue = '> '; // Initialize your property
    this.history = ["Welcome to DEATH, well possibly...", "The O'Ruggin Trail, no:23", "An experiment in on-chain text adventures"];
  }

  static styles = css`
    :host {
      display: block;
      min-height: 50px;
    }

    input {
      color: forestgreen;
      background: black;
      outline: none;
      border: black;
      font-family: 'Courier', sans-serif;
      font-size: 16px;
      width: 100%;
      box-sizing: border-box;
    }
    .terminal {
      color: forestgreen;
      background: black;
      border: 1px solid chartreuse;
      border-radius: 4px;
      font-family: 'Courier', sans-serif;
      font-size: 16px;
    }
  `;

  render() {
    return html`
      <div class="terminal">
        ${this.history.map(line => html`<div>${line}</div>`)}
        <input type="text" .value="${this.inputValue}" @keydown="${this.handleEnter}" @input=${this.handleInput}>
      </div>
    `;
  }
  private handleInput(e: Event) {
    const input = e.target as HTMLInputElement;
    const elem = e.target as EventTarget;
    let newVal = input.value;
    // @ts-ignore
    if (this.inputValue === newVal && this.inputValue !== (elem as HTMLInputElement ).value) {
      (elem as HTMLInputElement).value = this.inputValue;
    } else {
      this.inputValue = newVal;
    }
    // You can dispatch an event here if you want to notify parent components of the input change
  }

  private handleEnter(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      this.history = [...this.history, this.inputValue];
      this.inputValue = '> ';
    }
  }

}
customElements.define('l-terminal', LitTerminal);