const path = require('path'),
  webpack = require('webpack'),
  AssetsPlugin = require('assets-webpack-plugin'),
  BrotliPlugin = require('brotli-webpack-plugin'),
  UglifyJsPlugin = require('uglifyjs-webpack-plugin'),
  MiniCssExtractPlugin = require('mini-css-extract-plugin'),
  FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin'),
  BrowserSyncPlugin = require('browser-sync-webpack-plugin');

const isProd = process.env.NODE_ENV === 'production';

const settings = {
  host: 'localhost',
  port: 3000,
  proxy: 'xxx',
};

/**
 * Plugins for dev environment
 */
const devPlugins = [
  new BrowserSyncPlugin({
    host: settings.host,
    port: settings.port,
    proxy: settings.proxy,
    open: false
  }),
  new FriendlyErrorsWebpackPlugin(),
  new MiniCssExtractPlugin({
    filename: '[name].css',
    chunkFilename: '[name].css'
  }),
  new AssetsPlugin({
    prettyPrint: true,
    filename: 'assets.json',
    path: path.resolve(__dirname, 'dist')
  }),
  new webpack.DefinePlugin({
    __ENV__: JSON.stringify(process.env.NODE_ENV || 'development')
  })
];

/**
 * Plugins for production environment
 */
const prodPlugins = [
  // don't think this is working...
  new BrotliPlugin({
    asset: '[path].br[query]',
    test: /\.(js|css|html|svg)$/,
    threshold: 10240,
    minRatio: 0.8
  }),
  new FriendlyErrorsWebpackPlugin(),
  new UglifyJsPlugin({
    cache: true,
    parallel: true,
    sourceMap: true
  }),
];

/**
 * Merging plugins on the basis of env
 */
const pluginList = isProd ? [...devPlugins, ...prodPlugins] : devPlugins;

module.exports = {
  devtool: isProd ? '' : 'inline-source-map',
  performance: { hints: false },
  entry: {
    main: './src/js/index.js'
  },
  output: {
    filename: isProd ? '[name].[chunkhash].js' : '[name].bundle.js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: 'babel-loader',
        exclude: /node_modules/
      },
      {
        test: /\.(s*)css$/,
        include: path.resolve(__dirname, 'src/scss/main.scss'),
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader'
        ]
      },
      {
        test: /\.(ttf|otf|eot|woff2?|png|jpe?g|gif|svg|ico)$/,
        use: ['file-loader']
      }
    ]
  },
  plugins: pluginList,
  optimization: {
    splitChunks: {
      cacheGroups: {
        commons: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all'
        }
      }
    },
    runtimeChunk: {
      name: 'manifest'
    }
  }
};
