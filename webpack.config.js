const path = require('path');
const HaxeLoader = require('haxe-loader');

module.exports = {
    entry: './src/Main.hx',
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'bundle.js'
    },
    module: {
        rules: [
            {
                test: /\.hx$/,
                use: [
                    {
                        loader: 'haxe-loader',
                        options: {
                            debug: true
                        }
                    }
                ]
            }
        ]
    },
    resolve: {
        extensions: ['.js', '.hx'],
        alias: {
            'three': path.resolve(__dirname, 'node_modules/three/build/three.js'),
            'buzz': path.resolve(__dirname, 'node_modules/buzz/dist/buzz.js')
        }
    },
    devServer: {
        contentBase: './dist',
        hot: true
    }
}; 