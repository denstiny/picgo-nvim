"""

 @author      : aero (2254228017@qq.com)
 @file        : imagePost
 @created     : 星期六 2月 26, 2022 20:08:57 CST
 @github      : https://github.com/denstiny
 @blog        : https://denstiny.github.io

"""

import os
import json
import sys
import requests
import subprocess
import datetime
from pynvim import attach
nvim = attach('child', argv=["/bin/env", "nvim", "--embed", "--headless"])
head = nvim.eval('g:picgo_server')


class PostImage:
    def __init__(self):
        self.xclip_path = ' '
        pass

    def currentTime(self,filetype):
        """

        Args:
            filetype (): 文件后缀

        Returns: 返回当前时间的文件名称
            
        """
        time = datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
        return time+filetype

    def PostImage(self, head,filedir):
        """
        上传图片到图床
        Args:
            head (): 请求头字典
            files (): 文件包装数组

        Returns:
            返回图片链接,否则返回False
        """
        data = { "apiType":'majorhua', "token":head['token'] }
        file = self.FileOpen(filedir)
        if file ==  False:
            return False
        res = requests.post(url= head['url'],data=data,files=file['files'])
        jsonString = res.content.decode()
        userData = json.loads(jsonString)
        if userData['code'] != 200 and userData['msg'] != 'success':
            print("error:Upload failed",file=sys.stderr)
            return False
        file['image'].close()
        return userData['data']['url']['distribute']

    def FileOpen(self,filePath):
        """

        Args:
            filePath (): 文件路径

        Returns:
            返回包装好的文件数组
        """
        if os.path.exists(filePath) ==  False:
            print("error:No such file or directory",sys.stderr)
            return False
        image = open(filePath,'rb')
        imageName = os.path.basename(filePath)
        files = {"image":(imageName,image,'image/jpeg')}
        return {"files":files,"image":image}

    def get_xclip(self,cmd):
        """
        执行查找和保存图片的命令，并返回状态
        Args:
            cmd (): 执行的shell命令

        Returns:
            成功 返回True 失败 返回False
        """

        sub = subprocess.run(cmd,shell=True,stdout=subprocess.PIPE)
        return sub.returncode

    def getClipFileImage(self):
        """ 获取剪切板图片 """
        has_png = "xclip -selection clipboard -t TARGETS -o | grep image/png"
        has_jpg = "xclip -selection clipboard -t TARGETS -o | grep image/jpg"
        save_png = "xclip -selection clipboard -t image/png -o > "
        save_jpg = "xclip -selection clipboard -t image/jpg -o > "
        if self.get_xclip(has_png) ==  0:
            file_path = self.currentTime('.png')
            self.get_xclip(save_png + file_path)
            image_url = self.PostImage(head['遇见图床'],file_path)
            if image_url != False:
                os.remove(file_path)
                return image_url

        elif self.get_xclip(has_jpg) ==  0:
            file_path = self.currentTime('.jpg')
            self.xclip_path = file_path
            self.get_xclip(save_jpg + file_path)
            image_url = self.PostImage(head['遇见图床'],file_path)
            if image_url != False:
                os.remove(file_path)
                return image_url

        else:
            print("error:no find xclip image",file=sys.stderr)
            return False

    def __del__(self):
        if self.xclip_path != '':
            try:
                os.remove(self.xclip_path)
            except Exception:
                pass
        pass


def uploadPathImage(image):
    tool = PostImage()
    imageUrl = tool.PostImage(head['遇见图床'],image)
    if imageUrl != False:
        print("![](" + imageUrl +")")

def uploadXclipImage():
    tool = PostImage()
    imageUrl = tool.getClipFileImage()
    if imageUrl != False:
        print("![](" + imageUrl +")")

if __name__ == "__main__":
    if len(sys.argv) ==  2:
        uploadPathImage(sys.argv[1])
    else:
        uploadXclipImage()
