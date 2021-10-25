import React from 'react';
import Card from 'react-bootstrap/Card';
import CardGroup from 'react-bootstrap/Card';
import Button from 'react-bootstrap/Button';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import InputGroup from 'react-bootstrap/InputGroup';
import FormControl from 'react-bootstrap/FormControl';
import 'bootstrap/dist/css/bootstrap.min.css';
import css from './Cards.css';


const Cards = (props) => {
   
    return (
      <div className="Cards">
        <Row xs={3}>
            <Col>
            <Card
            bg="dark"
            border="info"
            text="white"
            >
                <Card.Header as="h4">{props.title1}</Card.Header>
                <Card.Body>
                <Card.Text as="h5">
                    {props.text1}
                </Card.Text><br/>
                <InputGroup className="mb-3" bg="primary">
                    <FormControl
                    onChange={props.onChange1}
                    placeholder={props.placeholder1}
                    />
                    <Button 
                    variant="outline-secondary"
                     id="button-addon2" 
                     onClick={props.onClick1}>
                    {props.button1}
                    </Button>
                </InputGroup>
                </Card.Body>
             </Card>
            </Col>
                <Col>
            <Card
                bg="dark"
                border="info"
                text="white"
            >
                <Card.Header as="h4">{props.title2}</Card.Header>
                <Card.Body>
                <Card.Text as="h5">
                    {props.text2}
                </Card.Text><br/>
                <InputGroup className="mb-3" bg="primary">
                    <FormControl
                    onChange={props.onChange2}
                    placeholder={props.placeholder2}
                    />
                    <Button variant="outline-secondary" id="button-addon2" onClick={(e) => console.log(e.target.value)}>
                    {props.button2}
                    </Button>
                </InputGroup>
                </Card.Body>
            </Card>
            </Col>
            <Col>
            <Card
                bg="dark"
                border="info"
                text="white"
            >
                <Card.Header as="h4">{props.title3}</Card.Header>
                <Card.Body>
                <Card.Text as="h5">
                    {props.text3}
                </Card.Text><br/>
                <InputGroup className="mb-3" bg="primary">
                    <FormControl
                    placeholder={props.placeholder3}
                    onChange={props.onChange3}
                    />
                    <Button 
                    variant="outline-secondary"
                     id="button-addon2"
                     onClick={props.onClick3}
                     >
                        {props.button3}
                    </Button><br/>
                </InputGroup>
                </Card.Body>
                <Button 
                    variant="success"
                    onClick={props.sendEth}
                >
                   Send ETH to my Account
                </Button>
            </Card>
            </Col>
        </Row>
    </div>
    );
  }
  

export default Cards;


