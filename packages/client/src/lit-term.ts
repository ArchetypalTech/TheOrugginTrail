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

  constructor() {
    super();
    this.inputValue = '> '; // Initialize your property
    // @ts-ignore
    this.history = [
       "Archetypal Tech welcomes you to DEATH"
      , "well possibly..."
      , "\n"
      , "The O'Ruggin Trail, no:23"
      , "\n"
      , "from the good folk at"
      , "Best Archetypal System Terminals And Retrograde Devices"
      , "\n"
    ];
  }

  static styles = css`
      :host {
          display: block;
          margin: 0;
      }

      textarea {
          color: forestgreen;
          background: black;
          outline: none;
          border: black;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          width: 100%;
          box-sizing: border-box;
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
      .output {
          margin-bottom: 8px;
          white-space: pre-wrap;
      }
  `;

  render() {
    return html`
      <div class="terminal">
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
    // You can dispatch an event here if you want to notify parent components of the input change


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