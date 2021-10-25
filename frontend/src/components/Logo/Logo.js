import React from 'react';
import css from './Logo.css';
import logo from '../../images/Logo.png';

const Logo = () => {
    return (
        <div className="Logo">
            <img src={logo} width="120"/>
        </div>
    );
}

export default Logo;