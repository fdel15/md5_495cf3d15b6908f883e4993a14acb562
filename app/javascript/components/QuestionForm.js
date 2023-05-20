import React from "react";
import PropTypes from "prop-types";

class QuestionForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: this.props.question || "",
      hideSubmit: false,
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({ value: event.target.value });
  }

  handleSubmit(event) {
    this.setState({ hideSubmit: true });
    this.props.handleQuestionSubmit(this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Ask a question:
          <textarea
            type="text"
            value={this.state.value}
            onChange={this.handleChange}
          />
        </label>

        <div
          className="buttons"
          style={{ display: this.state.hideSubmit ? "none" : "block" }}
        >
          <button type="submit" id="ask-button">
            Ask question
          </button>
        </div>
      </form>
    );
  }
}

export default QuestionForm;
