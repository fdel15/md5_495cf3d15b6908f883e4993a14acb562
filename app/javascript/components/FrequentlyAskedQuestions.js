import React from "react";
import PropTypes from "prop-types";
class FrequentlyAskedQuestions extends React.Component {
  handleClick = (queryText) => {
    this.props.handleQuestionSubmit(queryText);
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  };

  render() {
    return (
      <React.Fragment>
        <div id="faq">
          <h2>Frequently Asked Questions</h2>
          <ul className="faq_list">
            {this.props.questions.map((query_text, index) => (
              <li
                className="faq_query_text"
                key={index}
                onClick={() => this.handleClick(query_text)}
              >
                {query_text}
              </li>
            ))}
          </ul>
        </div>
      </React.Fragment>
    );
  }
}

FrequentlyAskedQuestions.propTypes = {
  questions: PropTypes.arrayOf(PropTypes.string).isRequired,
};

export default FrequentlyAskedQuestions;
