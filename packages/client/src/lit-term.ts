import { LitElement, html, css } from 'lit';

class LitTerminal extends LitElement {

  // static properties = (inputValue: {type: String}, history: {type: Array});
  constructor() {
    super();
    this.inputValue = ''; // Initialize your property
    this.history = ["Welcome to DEATH, well possibly...", "The O'Ruggin Trail, no:23"];
  }

  static styles = css`
      :host {
          display: block;
          min-height: 50px;
      }
      input {
          padding: 8px;
          background: black;
          border: 1px solid chartreuse;
          border-radius: 4px;
          font-family: 'Arial', sans-serif;
          font-size: 16px;
      }
  `;

  static get properties() {
    return {
      inputValue: { type: String }
    };
  }

  // @state() private command = '';
  // @state() private history: string[] = [];
  // @state private placeHolder: string = 'Type Here:>';

  render() {
    return html`
      <div class="terminal">
        ${this.history.map(line => html`<div>${line}</div>`)}
        <input type="text" placeholder=">" .value="${this.inputValue}" @keydown="${this.handleEnter}" @input=${this.handleInput}>
      </div>
    `;
  }
  private handleInput(e: Event) {
    const input = e.target as HTMLInputElement;
    const elem : EventTarget = e.target;
    let newVal = input.value;
    if (this.inputValue === newVal && this.inputValue !== elem.value) {
      elem.value = this.inputValue;
    } else {
      this.inputValue = newVal;
    }
    // You can dispatch an event here if you want to notify parent components of the input change
  }

  private handleEnter(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      this.history = [...this.history, this.inputValue];
      this.inputValue = '';
    }
  }
  //
  // private updateCommand(e: Event) {
  //   this.command = (e.target as HTMLInputElement).value;
  // }
}
customElements.define('l-terminal', LitTerminal);