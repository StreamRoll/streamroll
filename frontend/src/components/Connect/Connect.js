import React from 'react';
import css from './Connect.css';
import connect from '../../images/Connect.png';

const Connect = (props) => {
    return (
        <div className="Connect">
            <img 
                src={connect} 
                width="150" 
                onClick={props.onClick}
                style={{cursor:"pointer"}}/>
        </div>
    );
}

export default Connect;