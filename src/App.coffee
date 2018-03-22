import React, { Component } from 'react'

# import scores from './scores.json'

class App extends Component
  constructor: ->
    super()
    @state =
      input: ''
      error: ''
      # metadata: scores
      metadata: {}
      data: {}
      loading: false

  handleInputChange: (e) =>
    @setState { input: e.target.value }

  handleSubmit: (e) =>
    e.preventDefault()
    # @setState { input: '' }
    @fetchData()

  fetchData: () =>
    @setState {
      error: ''
      data: {}
      metadata: {}
    }
    { input } = @state
    authorAndPermlink = input.split('@')[1]
    if !authorAndPermlink
      @setState { error: 'link not valid' }
    else
      [ author, permlink ] = authorAndPermlink.split('/')
      if !permlink
        @setState { error: 'link not valid' }
      else
        postData =
          id: 1
          jsonrpc: "2.0"
          method: "call"
          params: [
            "database_api"
            "get_content" 
            [
              author
              permlink
            ]
          ]

        request = new Request 'https://api.steemit.com/', {
          method: 'POST'
          body: JSON.stringify postData
          headers: new Headers {
            'content-type': 'application/json'
          }
        }

        @setState {
          loading: true
          metadata: {}
          data: {}
        }

        fetch request
          .then (res) =>
            return res.json()
          .then (data) =>
            result = data.result
            metadata = {}
            try
              metadata = JSON.parse result.json_metadata

            @setState {
              data: result
              metadata
              loading: false
            }
          .catch (err) =>
            console.log err

  renderScore: ->
    { score, type, moderator, questions } = @state.metadata

    <div className="scores-wrap">
      <table>
        <tbody>
          <tr>
            <td>Title</td>
            <td>:</td>
            <td>
              <a
                href="https://utopian.io/@#{@state.data.author}/#{@state.data.permlink}"
                target="_blank">
                { @state.data.title }
              </a>
            </td>
          </tr>
          <tr>
            <td>Category</td>
            <td>:</td>
            <td>{ type }</td>
          </tr>
        </tbody>
      </table>
      <div className="questions-wrap">
        { questions.map (q, i) => (
          <div
            key={i}
            className="question-wrap"
          >
            <h4 className="question">{ q.question }</h4>
            <div className="answers-wrap">
              { q.answers.map (a, j) => (
                <div
                  key={j}
                  className="answer#{if a.selected then " selected" else "" }">
                  • { a.value } ({ a.score })
                </div>
              )}
            </div>
          </div>
        )}
      </div>
      <div className="summary">
        <div>Score: { score }</div>
      </div>
    </div>

  renderLoading: ->
    <h3 className="loading">Loading...</h3>

  render: ->
    <div className="wrapper">
      <h3 className="title">
        See your contribution score in utopian-io
      </h3>
      <form
        className="form"
        onSubmit={ @handleSubmit }
      >
        <input
          className="input"
          type="text"
          placeholder="for example: https://utopian.io/@username/your-contribution"
          value={ @state.input }
          onChange={ @handleInputChange }
        />
        <input
          className="submit"
          type="submit"
          value="Submit"
        />
      </form>
      <div className="label">Copy your utopian contribution link here</div>

      <h4 class="loading">{ @state.error }</h4>

      { @state.loading and @renderLoading() }
      { @state.metadata.score and @renderScore() }

    </div>

export default App