import React from "react";
import PropTypes from "prop-types";
class QuestionAnswer extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <React.Fragment>
        <div id="answer-container">
          <div id="question">
            <p>{this.props.question}</p>
          </div>
          <div id="answer">{this.props.answer}</div>
        </div>
      </React.Fragment>
    );
  }
}

QuestionAnswer.propTypes = {
  answer: PropTypes.string.isRequired,
};
export default QuestionAnswer;
