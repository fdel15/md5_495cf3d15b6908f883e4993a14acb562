import React from "react";
import PropTypes from "prop-types";
import QuestionForm from "./QuestionForm";
import QuestionAnswer from "./QuestionAnswer";
class HomePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      question: this.props.question || "",
      answer: this.props.answer || "",
    };

    this.handleQuestionSubmit = this.handleQuestionSubmit.bind(this);
  }

  handleQuestionSubmit = (question) => {
    this.setState({ answer: question });
    console.log("Question Submitted!");
    console.log(this.state);
  };

  render() {
    const { question, answer } = this.state;

    let hasAnswer = !!answer;

    return (
      <React.Fragment>
        <div class="main">
          <QuestionForm
            question={question}
            handleQuestionSubmit={this.handleQuestionSubmit}
          />
          {hasAnswer && <QuestionAnswer answer={answer} />}
        </div>
      </React.Fragment>
    );
  }
}

HomePage.propTypes = {
  question: PropTypes.string,
  answer: PropTypes.string,
};
export default HomePage;
