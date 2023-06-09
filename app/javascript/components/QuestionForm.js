import React from "react";
import PropTypes from "prop-types";

class QuestionForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: this.props.question || "",
    };
  }

  handleChange = (event) => {
    this.setState({ value: event.target.value });
  };

  handleSubmit = (event) => {
    this.props.handleQuestionSubmit(this.state.value);
    this.setState({ value: "" });
    event.preventDefault();
  };

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          <h3>Ask a question:</h3>
          <textarea
            type="text"
            value={this.state.value}
            onChange={this.handleChange}
          />
        </label>

        <div className="buttons">
          <button type="submit" id="ask-button">
            Ask question
          </button>
        </div>
      </form>
    );
  }
}

QuestionForm.propTypes = {
  question: PropTypes.string,
};

export default QuestionForm;
