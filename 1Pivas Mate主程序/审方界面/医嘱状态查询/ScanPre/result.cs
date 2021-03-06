﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;

namespace ScanPre
{
    public partial class result : UserControl
    {
        public result()
        {
            InitializeComponent();
        }

        public void setResult()//设置当前处方的审方结果
        {
            lblResource.Text = "通过";
        }
        public void setResult1(DataRow R)//设置当前处方的系统审方结果
        {
            try
            {

                lblResource.Text = "来源：" + R["ReferenName"].ToString()+ ")";
                lblResult.Text = R["CensorItem"].ToString();
                lblDesc.Text = "描述：" + R["Description"].ToString();
                durg1.Text = R["药品简称1"] == null ? "" : R["药品简称1"].ToString();
                durg2.Text = R["药品简称2"] == null ? "" : R["药品简称2"].ToString();
                NewMethod();
                switch (R["Level"].ToString())
                {
                    case "3":
                        pnl3.Visible = true;
                        pnl5.Visible = false;
                        break;
                    case "5":
                        pnl3.Visible = false;
                        pnl5.Visible = true;
                        break;
                }
            }
            catch (System.Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public void setResult(DataRow R)//设置当前处方的人工审方结果
        {
            try
            {

                lblResource.Text = "来源：" + R["ReferenName"].ToString() + "--" + R["DEmployeeName"].ToString() + "(" + R["AccountID"].ToString() + ")";
                    lblResult.Text = R["CensorItem"].ToString();
                    lblDesc.Text = "描述：" + R["Description"].ToString();

                    durg1.Text = R["药品简称1"] == null|| R["药品简称1"].ToString() ==""  ? "药品1" : R["药品简称1"].ToString();
                    durg2.Text = R["药品简称2"] == null|| R["药品简称2"].ToString() == "" ? "药品2" : R["药品简称2"].ToString();
                    NewMethod();
                switch (R["Level"].ToString())
                {
                    case "3":
                        pnl3.Visible = true;
                        pnl5.Visible = false;
                        break;
                    case "5":
                        pnl3.Visible = false;
                        pnl5.Visible = true;
                        break;
                }
            }
            catch (System.Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void NewMethod()
        {
            if (durg1.Text.Trim() != "")
            {

                if (lblDesc.Text == "")
                {
                    durg1.Location = new Point(durg1.Location.X, lblResult.Location.Y + lblResult.Height + 5);
                }
                else
                {
                    int w = lblDesc.MaximumSize.Width / 25;
                    int len = (lblDesc.Text.Length/2) / w;
                    durg1.Location = new Point(durg1.Location.X, lblDesc.Location.Y + (len * 12)+15);
                }
                lblResource.Location = new Point(lblResource.Location.X, durg1.Location.Y + durg1.Height);
            }
            else
            {

                durg1.Text = "";
            }
            if (durg2.Text .Trim() != "")
            {

                if (durg1.Text != "")
                {
                    durg2.Location = new Point(durg2.Location.X, durg1.Location.Y + durg1.Height + 5);
                }
                else
                {
                    if (lblDesc.Text == "")
                    {

                        durg2.Location = new Point(durg2.Location.X, lblResult.Location.Y + lblResult.Height + 5);

                    }
                    else
                    {
                        durg2.Location = new Point(durg2.Location.X, lblDesc.Location.Y + lblDesc.Height + 5);
                    }

                }
                lblResource.Location = new Point(lblResource.Location.X, durg2.Location.Y + durg2.Height);
            }
            else
            {
                durg2.Text = "";

            }
            if (pnl5.Location.X - 15 + pnl5.Width > this.Width)
            {
                //pnl5.Location = new Point(pnl5.Location.X - 15, lblResource.Location.Y + lblResource.Height);
                //pnl3.Location = new Point(pnl3.Location.X - 15, lblResource.Location.Y + lblResource.Height);
            }
            else
            {
                //pnl5.Location = new Point(pnl5.Location.X - 15, lblResource.Location.Y);
                //pnl3.Location = new Point(pnl3.Location.X - 15, lblResource.Location.Y);
            }

        }

        private void result_Click(object sender, EventArgs e)
        {
            this.Parent.Focus();
        }

        private void result_SizeChanged(object sender, EventArgs e)
        {
            lblDesc.MaximumSize = new Size(this.Width-lblDesc.Location.X-50,0);
            NewMethod();
        }
    }
}
