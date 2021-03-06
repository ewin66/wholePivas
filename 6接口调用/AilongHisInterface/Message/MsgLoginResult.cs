﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace AilongHisInterface.Message
{
    /// <summary>
    /// 药师登录状态实体
    /// </summary>
    public class MsgLoginResult : MsgBase
    {
        public MsgLoginResult()
        {
            this.MsgType = (short)MsgConstantType.LoginStatus;
        }
        /// <summary>
        /// 药师名字
        /// </summary>
        public string EmployeeName { get; set; }
        /// <summary>
        /// 药师登录状态，0未登录状态，1登录状态
        /// </summary>
        public short Status { get; set; }
    }
}
