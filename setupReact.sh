#!/bin/bash

WEBPACK_CONFIG='webpack.config.js'
ENTRY='src/index.js'
JS_BUNDLE='bundle.js'
HTML_TEMPLATE='src/index.html'
BUILD_DIR='build'
DEFAULT_PROJECT='new-project'
PROJECT_NAME=''
TIMESTAMP=''
TIMENOW=''

changeDirectory () {
    echo "Going in to ${PROJECT_NAME} ..."
    cd ${PROJECT_NAME}
}

configureWebpack () {

    echo "Creating ${WEBPACK_CONFIG} ..."

cat <<webpackconfig > ${WEBPACK_CONFIG}
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    entry : './${ENTRY}',
    output: {
        path: path.resolve(__dirname, '${BUILD_DIR}'),
        filename: '${JS_BUNDLE}'
    },
    module: {
        rules: [
            { test: /\.(js)$/, use: 'babel-loader' },
            { test: /\.css$/, use: [ 'style-loader', 'css-loader' ] }
        ]
    },
    mode: 'development',
    plugins: [
        new HtmlWebpackPlugin ({
            template: '${HTML_TEMPLATE}'
        })
    ]
}
webpackconfig
}

createSourceFiles () {
    mkdir src
    mkdir src/components


    echo "Creating ${ENTRY} ..."
cat <<indexjs > ${ENTRY}
import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';

function App () {
    return (
        <React.Fragment>
            Hello there. Welcome to React!
        </React.Fragment>
    );
}

ReactDOM.render( <App />, document.querySelector('#app') );
indexjs



    echo "Creating ${HTML_TEMPLATE} ..."
cat << indexhtml > ${HTML_TEMPLATE}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Github Battle</title>
</head>
<body>
    <div id="app"></div>
</body>
</html>
indexhtml


    echo "Creating src/index.css ..."
    touch src/index.css
}

createProjectDir() {
    if [ -d $1 ]
    then
        echo "'$1' already exists. Backing up to '$1_${TIMESTAMP}_${TIMENOW}'"
        mv $1 $1_${TIMESTAMP}_${TIMENOW}
    fi
    
    echo "Creating '$1' ..."
    mkdir $1
}

initializeProject () {
    npm init -y
}

installReact() {
    echo 'Installing ReactJs packages ...'
    npm install prop-types react react-dom react-icons
}

installWebpack() {
    echo 'Installing Webpack packages and plugin ...'
    npm install --save-dev webpack webpack-cli webpack-dev-server html-webpack-plugin 
}

installLoaders() {
    echo 'Installing loaders ...'
    npm install --save-dev babel-loader css-loader style-loader svg-loader
}

installBabel() {
    echo 'Installing Babel packages ...'
    npm install --save-dev @babel/core @babel/preset-env @babel/preset-react
}

setProjectName() {
    if [ $# -lt 1 ]
    then
        PROJECT_NAME=${DEFAULT_PROJECT}-`setTimestamp`
    else
        PROJECT_NAME=$1
    fi
}

setTimestamp() {
    TIMESTAMP=`date +"%Y-%m-%d"`
    TIMENOW=`date +"%H-%M-%S"`
    echo $TIMESTAMP
}

setupPackageJson () {
    node <<FILE > temp.json
        var data = require('./package.json')

        delete data.scripts

        data.scripts = {
            "build": "webpack",
            "start": "webpack-dev-server"
        };

        data.babel = {
            "presets": [
            "@babel/preset-env",
            "@babel/preset-react"
            ]
        };

        console.log(JSON.stringify(data, null, 2));
FILE

    mv temp.json package.json
}

##### MAIN BEGINS HERE #####

setTimestamp

setProjectName "$@"

createProjectDir ${PROJECT_NAME}

changeDirectory

initializeProject

installReact

installWebpack

installLoaders

installBabel

setupPackageJson

createSourceFiles

configureWebpack