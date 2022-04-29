// SPDX-License-Identifier: Apache-2.0
// Copyright Authors of Spiderpool

package framework

import (
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/klog/v2"
)

const SpiderLabelSelector = "app.kubernetes.io/name: spiderpool"

type Framework struct {
	BaseName        string
	SystemNameSpace string
	KubeClientSet   kubernetes.Interface
	KubeConfig      *rest.Config
}

// NewFramework init Framework struct
func NewFramework(baseName, kubeconfig string) *Framework {
	f := &Framework{BaseName: baseName}

	if kubeconfig == "" {
		klog.Fatal("kubeconfig must be specify")
	}
	klog.Info("kubeconfig: ", kubeconfig)
	cfg, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		klog.Fatal(err)
	}
	f.KubeConfig = cfg

	cfg.QPS = 1000
	cfg.Burst = 2000
	kubeClient, err := kubernetes.NewForConfig(cfg)
	if err != nil {
		klog.Fatal(err)
	}

	f.KubeClientSet = kubeClient

	return f
}
