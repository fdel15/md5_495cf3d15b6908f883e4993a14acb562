import React from "react";
import PropTypes from "prop-types";
class QuestionAnswer extends React.Component {
  render() {
    return (
      <React.Fragment>
        <p id="answer-container">
          <strong>Answer:</strong> <span id="answer">{this.props.answer}</span>
          <button id="ask-another-button" style={{ display: "block" }}>
            Ask another question
          </button>
        </p>
      </React.Fragment>
    );
  }
}

QuestionAnswer.propTypes = {
  answer: PropTypes.string,
};
export default QuestionAnswer;
