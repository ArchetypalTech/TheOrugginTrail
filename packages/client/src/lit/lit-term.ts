import { LitElement, html, css } from 'lit';
import termStyle from "../styles/termStyle";

export class LitTerminal extends LitElement {
  declare inputValue: string;
  declare history: Array<string>;
  declare headerText: Array<string>;
  static get properties() {
    return {
      inputValue: { type: String },
      history: {type: Array},
      headerText: {type: Array}
    };
  }

  constructor() {
    super();
    this.inputValue = '> '; // Initialize your property
    // @ts-ignore
    this.history = [
      "\n"
    ];
    this.headerText = [
      "Archetypal Tech welcomes you to DEATH"
      , "well possibly..."
      , "\n"
      , "The O'Ruggin Trail, no:23"
      , "from the good folk at"
    ];
  }

  // @ts-ignore
  static styles = css([termStyle]);

  render() {
    return html`
      <div class="terminal">
        ${this.headerText.map(line => html`<div class="headerOutput">${line}</div>`)}
        <div class="bastard">Best Archetypal System Terminals And Retrograde Devices</div>
        ${this.history.map(line => html`<div class="output">${line}</div>`)}
        <input type="text" .value="${this.inputValue}"
                  @keydown="${this.handleEnter}"
                  @input=${this.handleInput}>
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
  }

  private stripCommandString(s: string) {
    let seq = "> ";
    return s.replace(seq, "");
  }

  private handleEnter(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      const commandStr = this.stripCommandString(this.inputValue);
      this.dispatchEvent(new CustomEvent('command-update', {
        detail: { value: commandStr },
        bubbles: true, // Allows the event to bubble up through the DOM
        composed: true // Allows the event to cross the shadow DOM boundary
      }));
      this.history = [...this.history, commandStr];
      this.inputValue = '> ';
    }
  }

}
customElements.define('l-terminal', LitTerminal);