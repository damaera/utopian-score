import React, { Component } from 'react'

class App extends Component
  constructor: ->
    super()
    @state =
      input: ''
      error: ''
      metadata: {}
      loading: false

  handleInputChange: (e) =>
    @setState { input: e.target.value }

  handleSubmit: (e) =>
    e.preventDefault()
    @setState { input: '' }
    @fetchData()

  fetchData: () =>
    @setState { error: '' }
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

        @setState { loading: true }

        fetch request
          .then (res) =>
            return res.json()
          .then (data) =>
            result = data.result
            metadata = {}
            try
              metadata = JSON.parse result.json_metadata
              @setState {
                metadata
                loading: false
              }
          .catch (err) =>
            console.log err

  renderScore: ->
    { score, type, moderator, questions } = @state.metadata
    totalScore = 0
    questions.map (q) => totalScore += q.answers[0].score
    

    <div>
      <h3>{ score } / { totalScore }</h3>
    </div>

  renderLoading: ->
    <h3>Loading...</h3>

  render: ->
    <div>
      <form onSubmit={ @handleSubmit }>
        <input
          type="text"
          placeholder="ex: https://utopian.io/"
          value={ @state.input }
          onChange={ @handleInputChange }
        />
        <input type="submit" value="Submit" />
      </form>

      <h2>{ @state.error }</h2>

      { @state.loading and @renderLoading() }
      { @state.metadata.score and @renderScore() }

    </div>

export default App