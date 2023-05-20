import React from "react";
import PropTypes from "prop-types";
class QuestionAnswer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      clickUrl: this.props.clickUrl || "/", // default to root route
    };
  }

  handleClick = () => {
    // console.log("Handle Click rootUrl: ", this.rootUrl);
    window.location.href = this.state.clickUrl;
  };

  render() {
    return (
      <React.Fragment>
        <p id="answer-container">
          <strong>Answer:</strong> <span id="answer">{this.props.answer}</span>
          <button
            id="ask-another-button"
            style={{ display: "block" }}
            onClick={this.handleClick}
          >
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
