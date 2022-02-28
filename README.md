# 自动上传图片到图床

<!-- vim-markdown-toc GFM -->

* [安装](#安装)
* [配置](#配置)
* [演示](#演示)
* [常见问题](#常见问题)

<!-- vim-markdown-toc -->

> [chinese]() | [english]() 
![](https://www.hualigs.cn/image/621c4db64ef54.jpg) 
## 安装
> 使用你喜欢的插件管理工具  
- packer
```shell
use 'denstiny/picgo-nvim'
```
- plugin
```shell
plug "denstiny/picgo-nvim"
```
## 配置
```vim
let g:picgo_start = v:true
let g:picgo_server = {'遇见图床':{'url':'https://www.hualigs.cn/','token':'eaa4eb11884f7a60e03f5c2eab3161c8'}}
" 建议使用自己的 token
nmap <silent><A-p> :call UpdateImageX()<cr> " 上传剪切板图片
vmap <silent><A-o> :call UpdateImageR()<cr> " 上传指定位置图片
" UpdateImagePath path 指定路径
```
## 演示  

<https://user-images.githubusercontent.com/57088952/155927788-6a3efdca-921e-44ed-aeec-3da1cc6feaf9.mp4>  

## 常见问题
- 插件体验不佳
- **我是`vimscript`新手，有任何问题,或者好的建议欢迎提交** 
- 是否支持其他图床
- **正在积极开发，但是我时间有限，如果你可以贡献自己的`python`脚本，欢迎合并**
