/*
 * Copyright (C) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import fs from '@ohos.file.fs';

export class FileReader {
  // size of the file
  fileLength: number = 0
  // data length
  length: number = 0
  // read & write stream
  stream: fs.Stream | null = null
  // cache buf
  buf: ArrayBuffer = new ArrayBuffer(1)

  constructor(path: string) {
    if (!path) {
      return
    }
    try {
      this.stream = fs.createStreamSync(path, 'r+');
      let stat: fs.Stat = fs.statSync(path)
      this.fileLength = stat.size
    } catch (e) {
    }
  }

  /**
   * read file data
   */
  readLine(): string {
    let line = ''
    while (this.length <= this.fileLength) {
      if (!!this.stream) {
        let options: Record<string, number> = {
          'position': this.length
        }
        this.stream.readSync(this.buf, options)
      }
      this.length++
      let bufArray: number[] = Array.from(new Uint8Array(this.buf))
      let temp = String.fromCharCode(...bufArray);
      line = line + temp
      if (temp == '\n' || temp == '\r') {
        return line
      }
    }
    return line
  }

  /**
   * check file is end or not
   */
  isEnd() {
    return this.fileLength <= 0 || this.length == this.fileLength
  }

  /**
   * close stream
   */
  close() {
    if (!!this.stream) {
      this.stream.closeSync()
    }
  }
}