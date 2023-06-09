import React from "react";
import PropTypes from "prop-types";
import QuestionForm from "./QuestionForm";
import QuestionAnswer from "./QuestionAnswer";
import FrequentlyAskedQuestions from "./FrequentlyAskedQuestions";
class HomePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      faqs: this.props.faqs || "",
      answer: this.props.answer || "",
      dataFile: this.props.dataFile || "",
      loading: false,
    };
  }

  handleQuestionSubmit = async (question) => {
    const answer = await this.fetchAnswer(question);
    this.setState({ answer: answer, lastQuestion: question });
  };

  fetchAnswer = async (question) => {
    const { dataFile } = this.state;
    try {
      this.setState({ loading: true });
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
      this.setState({ loading: false });
      return data;
    } catch (error) {
      this.setState({ loading: false });
      console.error("Error:", error);
    }
  };

  render() {
    const { faqs, answer, lastQuestion, loading } = this.state;

    let hasAnswer = !!answer;

    return (
      <React.Fragment>
        <div class="main">
          {loading && <div class="spinner"></div>}
          {hasAnswer && (
            <QuestionAnswer answer={answer} question={lastQuestion} />
          )}
          <QuestionForm handleQuestionSubmit={this.handleQuestionSubmit} />

          <FrequentlyAskedQuestions
            questions={faqs}
            handleQuestionSubmit={this.handleQuestionSubmit}
          />
        </div>
      </React.Fragment>
    );
  }
}

HomePage.propTypes = {
  faqs: PropTypes.arrayOf(PropTypes.string),
  answer: PropTypes.string,
  dataFile: PropTypes.string,
};

export default HomePage;
