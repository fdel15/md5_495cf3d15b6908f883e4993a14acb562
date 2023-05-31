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
      dataFile: this.props.dataFile || "",
    };
  }

  handleQuestionSubmit = async (question) => {
    const answer = await this.fetchAnswer(question);
    this.setState({ answer: answer });
  };

  fetchAnswer = async (question) => {
    const { dataFile } = this.state;
    try {
      // Make the request
      const response = await fetch("/questions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({ question: question, data_file: dataFile }),
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error("Error:", error);
    }
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
