import React from 'react'
import css from  "./Card.css"


const App = (props) => {

    return (
        <div className="card-container">
            <div className="card-content-container">
                <p className="card-content">{props.value}</p>
            </div>
            <span className="card-name">{props.name}</span>
        </div>
    )
}

export default App;


